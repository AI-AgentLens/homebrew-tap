cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1088"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1088/agentshield_0.2.1088_darwin_amd64.tar.gz"
      sha256 "f65de28c8a3e5c4d9a0fee8218b9ffc693e53b7496e51c5a977a4236438d005b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1088/agentshield_0.2.1088_darwin_arm64.tar.gz"
      sha256 "b1a40ebf86ba611529e01d6cedf9b55c2b18d841e4838e72f931d96e14402b4f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1088/agentshield_0.2.1088_linux_amd64.tar.gz"
      sha256 "c01951fbe80ff4e17b5ab9f0fb92b32a906028ae053f7312e8115e4593f4cb69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1088/agentshield_0.2.1088_linux_arm64.tar.gz"
      sha256 "0e1ef2663c0e8adbacb173e369bbdbe9ed822ea4ffb5cac37d36808c0dcae8d6"
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
