cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.235"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.235/agentshield_0.2.235_darwin_amd64.tar.gz"
      sha256 "e7e10ae8e10210fbe12ba0b741521f5c4a6c01301afadd8fe3c4aa58e8649d7a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.235/agentshield_0.2.235_darwin_arm64.tar.gz"
      sha256 "c5bfded06056587ad4b33fee679172fc35c7c8acbe589302be1bd038233c64aa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.235/agentshield_0.2.235_linux_amd64.tar.gz"
      sha256 "31a11449c2769254df2fe669bd772ae3cf2fd8964c3c281c4c3ce7293867860e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.235/agentshield_0.2.235_linux_arm64.tar.gz"
      sha256 "4d8de6579acb9db25b972cca19d9501ccb76571f9013be021a37f8a48ee00462"
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
