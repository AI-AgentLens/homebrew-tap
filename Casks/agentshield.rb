cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1042"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1042/agentshield_0.2.1042_darwin_amd64.tar.gz"
      sha256 "61f4ba44e715a6fc75c53a2f2088c3f682bb4fa1698b41caaf4c4bd9d6602d84"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1042/agentshield_0.2.1042_darwin_arm64.tar.gz"
      sha256 "469922dff5fc6235cfba67253b8819ca87a700d469c2cb6cfa21801b187fdee6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1042/agentshield_0.2.1042_linux_amd64.tar.gz"
      sha256 "5f91d30c392c19d224a9c4208ef753126cb24342a6ffb8a8d8b06eed18d5c181"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1042/agentshield_0.2.1042_linux_arm64.tar.gz"
      sha256 "a98a7032586146fb823a8f4f024c4b700936ca590b6ff97151560625f0be2172"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
