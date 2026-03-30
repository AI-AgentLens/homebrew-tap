cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.234"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.234/agentshield_0.2.234_darwin_amd64.tar.gz"
      sha256 "a94546c6bc2212cecb5a53b55840edb03961442a7e3fbfdbf697a0cfbb814be3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.234/agentshield_0.2.234_darwin_arm64.tar.gz"
      sha256 "24f514749b016614b5519d47cc43dbffe21abd0c6fe37c18e4471970eced61fb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.234/agentshield_0.2.234_linux_amd64.tar.gz"
      sha256 "c1be4cca7b49e4f9b16eeda92da024e7f11d1b6092db323ac207e4e12b9cca6b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.234/agentshield_0.2.234_linux_arm64.tar.gz"
      sha256 "6137da90c1d9c8dddf68394a50f5a754dd1b2f11c117fc621c9648301706c3fb"
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
