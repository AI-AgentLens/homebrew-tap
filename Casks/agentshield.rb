cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2204"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2204/agentshield_0.2.2204_darwin_amd64.tar.gz"
      sha256 "261adc75c6006ebc35479128d723f53e618079059a318141f33bcb02469d3850"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2204/agentshield_0.2.2204_darwin_arm64.tar.gz"
      sha256 "370e0ecfce67b2e6af866b4cada0d6667635408c71b5d8a64f03ffec8be80233"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2204/agentshield_0.2.2204_linux_amd64.tar.gz"
      sha256 "9b510a94138f6def5967de6609c8060dece74e9a5569c97aa079d558d2cf7adf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2204/agentshield_0.2.2204_linux_arm64.tar.gz"
      sha256 "939ee522ed7cc022f7a6e9e4621228297cf1565cda8bf6f0d21885b7b61a4ac3"
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
