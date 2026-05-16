cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.996"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.996/agentshield_0.2.996_darwin_amd64.tar.gz"
      sha256 "09b65092fa93b5266985e109db3f697e8894a56f2d5ace332298b8dd3f43598f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.996/agentshield_0.2.996_darwin_arm64.tar.gz"
      sha256 "94756a1ae1ed5d19b7d24e07343f6893c39874f9172a3f107ea417c23453fb8b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.996/agentshield_0.2.996_linux_amd64.tar.gz"
      sha256 "95c77ee2542ff1c87a227eb37b069785af8716a27c02d5fcbfa313fd62d53cb4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.996/agentshield_0.2.996_linux_arm64.tar.gz"
      sha256 "5fbc95e555f8e7951d4b3c9019f64d826c3682deb29ac7db2df22c7ba564f896"
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
