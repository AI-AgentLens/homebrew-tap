cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2315"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2315/agentshield_0.2.2315_darwin_amd64.tar.gz"
      sha256 "1db2102769744e109944414e6bd49f38971c7a3feb5150af155f115cbf85414a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2315/agentshield_0.2.2315_darwin_arm64.tar.gz"
      sha256 "f844d6b31a5876096dc782a9aab5d65437667f660f9dd2fd9344c291dcdacb58"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2315/agentshield_0.2.2315_linux_amd64.tar.gz"
      sha256 "df98e817b7aeaa2257264cb8386a27813dca1ca1fcb5fef81c3aa0ad0e033770"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2315/agentshield_0.2.2315_linux_arm64.tar.gz"
      sha256 "d44e9b5938af5e7965a808c5724cc29132b79af88a795703ede4ba8ce7834f18"
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
