cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1202"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1202/agentshield_0.2.1202_darwin_amd64.tar.gz"
      sha256 "e079ee5ec7752bc8b43e3edef416de737cecf42e79040a24c683608b5050916b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1202/agentshield_0.2.1202_darwin_arm64.tar.gz"
      sha256 "7511c99eda7f7719d4c148b15c5dd28a7725c61d52929337f4fe9a555305d969"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1202/agentshield_0.2.1202_linux_amd64.tar.gz"
      sha256 "3656a450fa756a322cd4d08b2f1b87e90bab508bcdd90533c18b6b36b61fc5df"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1202/agentshield_0.2.1202_linux_arm64.tar.gz"
      sha256 "d523c70c08d53951f0276d466a978c09c23edf83960cfbc76f07165d47a244b6"
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
