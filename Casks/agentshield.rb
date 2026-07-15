cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1653"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1653/agentshield_0.2.1653_darwin_amd64.tar.gz"
      sha256 "cdb2de7ae7ed7309bd1e5fa8fb2e6864600e544d1fca4fb53e47ca69e5db6528"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1653/agentshield_0.2.1653_darwin_arm64.tar.gz"
      sha256 "32280ba66451c899469a8a0fe3b831bef890cd8cf380591cf806be09aae0a7ee"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1653/agentshield_0.2.1653_linux_amd64.tar.gz"
      sha256 "85eee36c05b53a6c8844d856b4c8a41e686ad68cdbfd59d3f0b83905f28209da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1653/agentshield_0.2.1653_linux_arm64.tar.gz"
      sha256 "f5029085462cd0808c16b59bb4f68e780e017ff014216f33898b1dac069dd22a"
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
