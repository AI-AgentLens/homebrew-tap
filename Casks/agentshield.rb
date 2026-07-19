cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1676"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1676/agentshield_0.2.1676_darwin_amd64.tar.gz"
      sha256 "542a2e28067ae83822fb64e25c67e67b38cea2466c29e0a66b6fa17538f74aab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1676/agentshield_0.2.1676_darwin_arm64.tar.gz"
      sha256 "bfd3533274fb4592679af38cbd4de6beeeb3594cf6fe6ae144dadad9d9c6990e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1676/agentshield_0.2.1676_linux_amd64.tar.gz"
      sha256 "b6461a5b7571c35525117374359930891ecafe8a651448a9af4163359d6b1a75"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1676/agentshield_0.2.1676_linux_arm64.tar.gz"
      sha256 "31c7d74e26f8619b44137c6095e2c0d6d001b1559b3cfb337d785ff3532c1047"
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
