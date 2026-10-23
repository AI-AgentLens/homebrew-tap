cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2505"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2505/agentshield_0.2.2505_darwin_amd64.tar.gz"
      sha256 "31700011df36f8a5593b379ee02bb74210e8adbbeab2ce8a2d3032af406e10ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2505/agentshield_0.2.2505_darwin_arm64.tar.gz"
      sha256 "a4041b5ff5c8998d62cb9244a4cbeffecb9294828c29de9c27ca4b418075411a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2505/agentshield_0.2.2505_linux_amd64.tar.gz"
      sha256 "242bc30881367016fdc90306a9d4039241d5b59896f3169cde5dd046c35f682a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2505/agentshield_0.2.2505_linux_arm64.tar.gz"
      sha256 "04749a284d2225643c39cb675b20e39fd6e9d645bf83b9d7d81be6ab3ded68bf"
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
