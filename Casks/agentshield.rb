cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1427"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1427/agentshield_0.2.1427_darwin_amd64.tar.gz"
      sha256 "d8af3508adcfef9f83fe094d28333610fd7bb98a0f9249e8cf1b35deb76bb20f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1427/agentshield_0.2.1427_darwin_arm64.tar.gz"
      sha256 "b0b709c3b88db0618e05b34f82ef0bfdef03f77660e7a23c439f23dbb7f63c8a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1427/agentshield_0.2.1427_linux_amd64.tar.gz"
      sha256 "eafaabf7a9945bc687bb1f0d54ba8a27bffe26ff3918c5a76bb7e98834752d49"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1427/agentshield_0.2.1427_linux_arm64.tar.gz"
      sha256 "5d97ddc59837552d3e9a4937223ba3b14c70e21941740a7e473bc4b9e8f89f84"
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
