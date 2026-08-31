cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2004"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2004/agentshield_0.2.2004_darwin_amd64.tar.gz"
      sha256 "52b5695fbdd4a30485426026d37e12b5babd32a4469022ac1a14225c351c457d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2004/agentshield_0.2.2004_darwin_arm64.tar.gz"
      sha256 "3aafcf6e714889d720811e7d89bc2caa6e412c19ce85020c05c0f2968afc37dc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2004/agentshield_0.2.2004_linux_amd64.tar.gz"
      sha256 "8a55bc77a41ebbafd37c0937d288d785abf49e7bdc87bee7a8fcc03df70dc8c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2004/agentshield_0.2.2004_linux_arm64.tar.gz"
      sha256 "803fd7ff6b27f9e3f793573638c77958e830e20c4e6bd865af4815921a907d6f"
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
