cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2083"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2083/agentshield_0.2.2083_darwin_amd64.tar.gz"
      sha256 "cadbfe6fce92facf0cbfbe0a52026b9927b95ac31875d7e72aff4b9e4f2b95aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2083/agentshield_0.2.2083_darwin_arm64.tar.gz"
      sha256 "c3076c0153abbcb720fdd65a8cdbcd40cf20ff55be5829b544bf6bb153c63f45"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2083/agentshield_0.2.2083_linux_amd64.tar.gz"
      sha256 "396bc31fa296e3071e6c85d0223f53a07b67919362f804f57e147efe01540367"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2083/agentshield_0.2.2083_linux_arm64.tar.gz"
      sha256 "84bc71befed3d3858df8459a93e0764e7fb10ac9735f0e9e2e27da09ef7cef65"
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
