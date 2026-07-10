cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1606"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1606/agentshield_0.2.1606_darwin_amd64.tar.gz"
      sha256 "3546708aa0d3ee98858c3cee9c0cfebbeea84b9dfbc90b09826f659d825170a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1606/agentshield_0.2.1606_darwin_arm64.tar.gz"
      sha256 "e0419401e02283ed0060b8b016ceae04ae371c957f4d3b92ced372e46130a654"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1606/agentshield_0.2.1606_linux_amd64.tar.gz"
      sha256 "8472f62a97e69799c07069cf703e7ced7dc6ff3e53f28908460cca26441b9a5b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1606/agentshield_0.2.1606_linux_arm64.tar.gz"
      sha256 "be6881223596ea4b48b9edab5f6edc249de6474ca56e591749df5e3083349764"
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
