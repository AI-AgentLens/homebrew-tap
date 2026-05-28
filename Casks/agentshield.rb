cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1137"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1137/agentshield_0.2.1137_darwin_amd64.tar.gz"
      sha256 "f03e86aeaccc05d87aec8f49ac7c2ebe0f4d841d8e75cf73c6801205bcc63b9a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1137/agentshield_0.2.1137_darwin_arm64.tar.gz"
      sha256 "625956acce89f2c34189fa464d937b2087f7283beb1873d2974980671bbefae7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1137/agentshield_0.2.1137_linux_amd64.tar.gz"
      sha256 "8d3978796dcd57edc2b61839c770b2f8affe2358f6de1f10d6cd227d503ed69c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1137/agentshield_0.2.1137_linux_arm64.tar.gz"
      sha256 "3f8769e4b257c2307bce2052b450c4825139c6c2bc7ce1749796611429ccebf8"
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
