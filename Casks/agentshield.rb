cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.355"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.355/agentshield_0.2.355_darwin_amd64.tar.gz"
      sha256 "2b7fd8295e012902ece0eaca9c1d661b4431ff46fbc53c6b8c9d255d37e1cf5d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.355/agentshield_0.2.355_darwin_arm64.tar.gz"
      sha256 "c420ad50a18d0fe00997c99686de1be9f1c57ded03cad984ea7ee2e6465b481a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.355/agentshield_0.2.355_linux_amd64.tar.gz"
      sha256 "f03dd911acc89a872e094f86567bd7bdc77e709c1a27e1c0f35b9c49b2331f86"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.355/agentshield_0.2.355_linux_arm64.tar.gz"
      sha256 "d40ad16c84af6f68d8340066d202fc8d556ae4c3bd418991c460f0b93260263a"
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
